package handler

import (
	"log"
	"net/http"
	"strconv"

	db "example.com/m/v2/db/sqlc"
	"example.com/m/v2/internal/service"
	"github.com/gin-gonic/gin"
	"github.com/jackc/pgx/v5/pgtype"
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

// Register Handles user registration
func (h *UserHandler) Register(c *gin.Context) {
	var input struct {
		FullName    string  `json:"full_name" binding:"required"`
		Email       string  `json:"email" binding:"required,email"`
		Password    string  `json:"password" binding:"required"`
		PhoneNumber *string `json:"phone_number"`
		Role        string  `json:"role"`        
	}

	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid input data: " + err.Error()})
		return
	}

	var params db.CreateUserParams
	params.FullName = input.FullName
	params.Email = input.Email
	params.PasswordHash = input.Password

	if input.PhoneNumber != nil {
		params.PhoneNumber = pgtype.Text{String: *input.PhoneNumber, Valid: true}
	} else {
		params.PhoneNumber = pgtype.Text{Valid: false}
	}

	if input.Role == "" {
		params.Role = db.RoleEnumCustomer 
	} else {
		params.Role = db.RoleEnum(input.Role)
	}

	user, err := h.userService.RegisterUser(c.Request.Context(), params)
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

	user, token,  err := h.userService.LoginUser(c.Request.Context(), input.Email, input.Password)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Login successful",
		"token"  : token,
		"user_id": user.ID,
		"email"  :   user.Email,
		"role"   :    user.Role,
	})
}

type profileOwnerValue struct{
	Email string `json:"Email" binding:"required,Email"`
}

func (h *UserHandler) GetUserByEmail(c *gin.Context) {
    loggedInEmail, exists := c.Get("email")
    if !exists {
        c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized: user email not found in context"})
        return
    }

    emailStr, ok := loggedInEmail.(string)
    if !ok {
        c.JSON(http.StatusInternalServerError, gin.H{"error": "Internal server error: invalid email type"})
        return
    }

    user, err := h.userService.GetUserByEmail(c.Request.Context(), emailStr)
    if err != nil {
        c.JSON(http.StatusNotFound, gin.H{"error": "User not found or " + err.Error()})
        return
    }

    c.JSON(http.StatusOK, gin.H{
        "message": "User profile fetched successfully",
        "data": gin.H{
            "name":  user.FullName,
            "email": user.Email,
            "role":  user.Role,
        },
    })
}

func (h *UserHandler) GetUserList(c *gin.Context) {
    // Default values
    limit := int32(10)
    offset := int32(0)

    // Query parameters parse kora
    if limitStr := c.Query("limit"); limitStr != "" {
        if parsedLimit, err := strconv.ParseInt(limitStr, 10, 32); err == nil {
            limit = int32(parsedLimit)
        }
    }

    if offsetStr := c.Query("offset"); offsetStr != "" {
        if parsedOffset, err := strconv.ParseInt(offsetStr, 10, 32); err == nil {
            offset = int32(parsedOffset)
        }
    }

    arg := db.ListCustomersParams{
        Limit:  limit,
        Offset: offset,
    }

    // Database theke data ana
    users, err := h.userService.GetUserList(c.Request.Context(), arg)
    if err != nil {
        // Log the actual error for debugging, user-ke simple message dekhano
        log.Printf("Error fetching user list: %v", err) 
        
        c.JSON(http.StatusInternalServerError, gin.H{
            "error": "Failed to fetch users",
        })
        return // CRITICAL: Error hole ekhanei thamaite hobe!
    }

    // Fix: users nil hole jate JSON-e null na giye [] (empty array) jay
    if users == nil {
        users = []db.ListCustomersRow{}
    }

    // Success Response
    c.JSON(http.StatusOK, gin.H{
        "message": "Users fetched successfully",
        "meta": gin.H{
            "limit":  limit,
            "offset": offset,
            "count":  len(users),
        },
        "data": users,
    })
}