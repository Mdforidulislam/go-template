package main

import (
	"context"
	"log"

	"example.com/m/v2/internal/handler"
	"example.com/m/v2/internal/repository"
	"example.com/m/v2/internal/service"

	"github.com/gin-gonic/gin"
	"github.com/jackc/pgx/v5/pgxpool"
)

func main() {
	ctx := context.Background()

	// ১. ডাটাবেজ কানেকশন পুল (dbPool) তৈরি
	dbPool, err := pgxpool.New(ctx, "postgres://postgres@localhost:5432/my_test_db?sslmode=disable")
	if err != nil {
		log.Fatalf("Unable to connect to database: %v", err)
	}
	defer dbPool.Close()

	// ২. dbPool পাস করে রেপোজিটরি তৈরি করলাম
	userRepo := repository.NewUserRepository(dbPool)

	// ৩. রেপোজিটরি পাস করে সার্ভিস তৈরি করলাম
	userService := service.NewUserService(userRepo)

	// ৪. এই যে কানেকশন! সার্ভিস পাস করে হ্যান্ডলার তৈরি করলাম
	userHandler := handler.NewUserHandler(userService)

	// ৫. জিনের একটি ডিফল্ট রাউটার ইঞ্জিন তৈরি করুন
	r := gin.Default()

	// ৬. রাউটারের সাথে হ্যান্ডলারের ফাংশনটি কানেক্ট বা ম্যাপ করুন
	// ক্লায়েন্ট যখন POST রিকোয়েস্ট পাঠাবে "/users" এ, তখন userHandler-এর CreateUser রান হবে
	r.POST("/users", userHandler.CreateUser)
	// ---- টেস্টিং এর জন্য GET মেথড (সরাসরি মেইন ফাইল থেকে ডাটা রিটার্ন) ----
	r.GET("/users", func(c *gin.Context) {
		// এখানে আমরা একটি নকল বা ডামি ইউজার ডেটা ম্যাপ করে রিটার্ন করছি
		c.JSON(200, gin.H{
			"id":      1,
			"name":    "Md Foridul Islam",
			"email":   "foridul@example.com",
			"role":    "Backend Developer",
			"message": "Hello! Main function থেকে সরাসরি ডাটা সাকসেসফুলি আসছে।",
		})
	})

	// ৭. সার্ভারটি চালু করুন (ডিফল্টভাবে পোর্ট ৮০৮০ তে রান হবে)
	log.Println("Server is running on port 8080...")
	r.Run(":8080")
}
