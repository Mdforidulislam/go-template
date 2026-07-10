package middleware

import (
	"net/http"
	"github.com/gin-gonic/gin"
)


func RequireRole(allowedRoles ...string) gin.HandlerFunc {
	return func(c *gin.Context) {

		userRole, exists := c.Get("role")
		if !exists {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized: No role found"})
			c.Abort()
			return
		}

		roleStr := userRole.(string)
		isAllowed := false
		for _, role := range allowedRoles {
			if roleStr == role {
				isAllowed = true
				break
			}
		}

		if !isAllowed {
			c.JSON(http.StatusForbidden, gin.H{"error": "Forbidden: You do not have permission to access this resource"})
			c.Abort()
			return
		}

		c.Next()
	}
}