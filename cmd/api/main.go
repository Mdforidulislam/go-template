package main

import (
	"context"
	"log"
	"net/http"
	"time"

	"example.com/m/v2/internal/handler"
	"example.com/m/v2/internal/middleware"
	"example.com/m/v2/internal/repository"
	"example.com/m/v2/internal/service"
	"github.com/gin-gonic/gin"
	"github.com/jackc/pgx/v5/pgxpool"
)

func main() {	
	ctx := context.Background()
	dbURI := "postgres://postgres@localhost:5432/my_test_db?sslmode=disable"
	config, err := pgxpool.ParseConfig(dbURI)
	if err != nil {
		log.Fatalf("Error with coneection database auth: %v", err)
	}

	config.MaxConns = 10                      
	config.MinConns = 2                        
	config.MaxConnIdleTime = 5 * time.Minute   

	dbPool, err := pgxpool.NewWithConfig(ctx, config)
	if err != nil {
		log.Fatalf("Fail to connection database: %v", err)
	}
	defer dbPool.Close() 

	if err := dbPool.Ping(ctx); err != nil {
		log.Fatalf("Don't response to database (Ping Failed): %v", err)
	}
	log.Println("Database connection successfully established!")

	// ========================================================
	// (Dependency Injection Chain)
	// ========================================================
	
	userRepo := repository.NewUserRepository(dbPool)
	userService := service.NewUserService(userRepo)
	userHandler := handler.NewUserHandler(userService)

	r := gin.Default()
	r.Use(gin.Recovery())

	r.GET("/health", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{"status": "UP", "message": "Server is healthy"})
	})

	api := r.Group("/api/v1")
	{
		api.POST("/users/register", userHandler.Register)
		api.POST("/users/login", userHandler.Login)
	}

	user := r.Group("/api/v1")
	user.Use(middleware.AuthMiddleware())
	{
		user.GET("/users/get-me", userHandler.GetUserByEmail)
	}

	// =====================================================
	// admin or private data here 
	// =====================================================
	adminAccess := r.Group("/api/v1/admin")
	adminAccess.Use(middleware.AuthMiddleware())
	adminAccess.Use(middleware.RequireRole("admin"))
	{
		adminAccess.GET("/user-list",userHandler.GetUserList)
	}
	
	port := ":8080"
	log.Printf("Server nicely started and listening on port %s...", port)
	if err := r.Run(port); err != nil {
		log.Fatalf("Fail to run server : %v", err)
	}
}