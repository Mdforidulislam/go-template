package handler

import (
	"net/http"

	db "example.com/m/v2/db/sqlc"
	"example.com/m/v2/internal/service"
	"github.com/gin-gonic/gin"
)

// UserHandler 
type UserHandler struct {
	userService service.UserService
}

// NewUserHandler 
func NewUserHandler(userService service.UserService) *UserHandler {
	return &UserHandler{
		userService: userService,
	}
}

// ==========================================
// --------- HTTP HANDLER METHODS -----------
// ==========================================

// Register
func (h *UserHandler) Register(c *gin.Context) {
	var input db.CreateUserParams

	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid input data: " + err.Error()})
		return
	}

	user, err := h.userService.RegisterUser(c.Request.Context(), input)
	if err != nil {
		c.JSON(http.StatusConflict, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"message": "User registered successfully",
		"data":    user,
	})
}

// Login Request
type LoginRequest struct {
	Email    string `json:"email" binding:"required,email"`
	Password string `json:"password" binding:"required"`
}

func (h *UserHandler) Login(c *gin.Context) {
	var input LoginRequest

	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	user, err := h.userService.LoginUser(c.Request.Context(), input.Email, input.Password)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Login successful",
		"user_id": user.ID,
		"email":   user.Email,
		"role":    user.Role,
	})
}