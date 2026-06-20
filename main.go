package main

import (
	"fmt"
	"log"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
)

// =============================================================
// SECTION 1: Higher-Order Function (Callback pattern)
//
// makeResponder একটা Higher-Order Function।
// এটা নিজে কিছু করে না — বরং একটা নতুন function return করে।
// সেই returned function টাই actual কাজ করে।
//
// এটাকে বলে "function factory" — একটা function যেটা
// factory-র মতো আরেকটা function বানিয়ে দেয়।
// =============================================================

func makeResponder(prefix string) func(string) string {
	// এই inner function টাই return হচ্ছে।
	// 'prefix' variable টা এখানে "close over" হয়ে যাচ্ছে —
	// এটাকে বলে "closure"।
	return func(name string) string {
		return fmt.Sprintf("[%s] Hello, %s! Time: %s", prefix, name, time.Now().Format("15:04:05"))
	}
}

// =============================================================
// SECTION 2: Logger Middleware
// 
// Middleware হলো একটা function যেটা route handler-এর
// আগে বা পরে চলে।
//
// Gin-এ middleware pattern:
//   func(c *gin.Context) {
//       // route handler-এর আগে যা করার করো
//       // c.Next()   ← এখানে actual route handler চলে
//       // route handler-এর পরে যা করার করো
//   }
// =============================================================

func LoggerMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		start := time.Now()

		// c.Next() call করলে পরের middleware বা
		// route handler চলে যায়
		c.Next()

		// route handler শেষ হওয়ার পরে এই অংশ চলে
		duration := time.Since(start)
		log.Printf(
			"[LOGGER] %s %s | Status: %d | Duration: %v",
			c.Request.Method,
			c.Request.URL.Path,
			c.Writer.Status(),
			duration,
		)
	}
}

// =============================================================
// SECTION 3: Login Check Middleware
//
// এটা দেখে request-এ "X-Login" header আছে কিনা।
// না থাকলে 401 দিয়ে request থামিয়ে দেয়।
// থাকলে c.Next() দিয়ে পরের handler-এ যেতে দেয়।
//
// c.Abort() → request chain থামায়, পরের কোনো
//             middleware বা route handler চলে না।
// c.Next()  → পরের middleware বা route handler-কে
//             চলতে দেয়।
// =============================================================

func LoginCheckMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		loginHeader := c.GetHeader("X-Login")

		if loginHeader == "" {
			// login নেই — 401 দিয়ে থামাও
			c.JSON(http.StatusUnauthorized, gin.H{
				"error": "login required",
				"hint":  "Request-এ 'X-Login: yourname' header দাও",
			})
			c.Abort() // পরের কিছু চলবে না
			return
		}

		// login আছে — username টা context-এ রেখে দাও
		// যেন route handler এটা ব্যবহার করতে পারে
		c.Set("loggedInUser", loginHeader)

		c.Next() // পরের middleware/handler-এ যাও
	}
}

// =============================================================
// SECTION 4: Calculator Function
//
// দুটো number নিয়ে একটা function return করে।
// সেই returned function টা দুটোকে যোগ করে।
// এটাও একটা Higher-Order Function-এর উদাহরণ।
// =============================================================

func calculator(a, b int) func() int {
	// এই function টা return হচ্ছে।
	// 'a' আর 'b' close over হয়ে আছে।
	return func() int {
		return a + b
	}
}

// =============================================================
// SECTION 5: Main — সব কিছু একসাথে
// =============================================================

func main() {
	r := gin.Default()

	// Global middleware — সব route-এর আগে চলবে
	r.Use(LoggerMiddleware())

	// /ping route — এখানে LoginCheckMiddleware শুধু
	// এই নির্দিষ্ট route-এর জন্য apply হচ্ছে
	r.GET("/ping", LoginCheckMiddleware(), func(c *gin.Context) {

		// Context থেকে logged-in user নাও
		// (LoginCheckMiddleware এটা Set করে রেখেছিল)
		user, _ := c.Get("loggedInUser")
		userName := fmt.Sprintf("%v", user)

		// makeResponder call করলে একটা নতুন function পাওয়া যায়।
		// সেই function-কে 'respond' variable-এ রাখা হলো।
		respond := makeResponder("PING-HANDLER")

		// এখন 'respond' নিজেই একটা function।
		// সেটাকে call করা হচ্ছে userName দিয়ে।
		message := respond(userName)

		// calculator এর Higher-Order Function দেখানো হচ্ছে
		add := calculator(10, 32)
		result := add() // 42 হবে


		c.JSON(http.StatusOK, gin.H{
			"message":         message,
			"calculator_demo": fmt.Sprintf("10 + 32 = %d", result),
			"logged_in_as":    userName,
		})
	})

	// /public route — কোনো login লাগবে না
	r.GET("/public", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"message": "এই route-এ login লাগে না",
		})
	})

	log.Println("Server চালু হচ্ছে :8080 এ...")
	log.Println("Test করো:")
	log.Println("  curl http://localhost:8080/ping                          → 401 পাবে")
	log.Println("  curl -H 'X-Login: Rahim' http://localhost:8080/ping     → 200 পাবে")
	log.Println("  curl http://localhost:8080/public                        → 200 পাবে")

	r.Run(":8080")
}


