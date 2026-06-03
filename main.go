package main

import (
	"database/sql"
	"fmt"
	"net/http"
	"os/exec"
	"io/ioutil"

	"github.com/gin-gonic/gin"
	jwt "github.com/dgrijalva/jwt-go"
	_ "github.com/lib/pq"
)

// Hardcoded credentials
const (
	DBPassword    = "SuperSecret123!"
	JWTSecret     = "hardcoded_jwt_secret"
	AWSAccessKey  = "AKIAIOSFODNN7EXAMPLE"
	AWSSecretKey  = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
	AdminPassword = "admin123"
	APIKey        = "sk-prod-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
)

var db *sql.DB

func main() {
	var err error
	// Hardcoded connection string
	db, err = sql.Open("postgres", "host=prod-db user=postgres password=SuperSecret123! dbname=appdb sslmode=disable")
	if err != nil {
		panic(err)
	}

	r := gin.Default()

	// SQL Injection
	r.GET("/user", func(c *gin.Context) {
		username := c.Query("username")
		// String formatting in SQL
		query := fmt.Sprintf("SELECT * FROM users WHERE username='%s'", username)
		rows, _ := db.Query(query)
		defer rows.Close()
		c.JSON(200, gin.H{"query": query})
	})

	// Command injection
	r.GET("/exec", func(c *gin.Context) {
		cmd := c.Query("cmd")
		// Direct execution of user input
		out, _ := exec.Command("sh", "-c", cmd).Output()
		c.String(200, string(out))
	})

	// Path traversal
	r.GET("/file", func(c *gin.Context) {
		filename := c.Query("name")
		// No path cleaning
		data, _ := ioutil.ReadFile("/var/www/" + filename)
		c.String(200, string(data))
	})

	// JWT without verification
	r.GET("/profile", func(c *gin.Context) {
		tokenString := c.GetHeader("Authorization")
		// ParseUnverified - no signature check!
		token, _, _ := new(jwt.Parser).ParseUnverified(tokenString, jwt.MapClaims{})
		c.JSON(200, token.Claims)
	})

	// SSRF
	r.GET("/fetch", func(c *gin.Context) {
		url := c.Query("url")
		// No URL validation
		resp, _ := http.Get(url)
		body, _ := ioutil.ReadAll(resp.Body)
		c.String(200, string(body))
	})

	// Gin debug mode in production
	r.Run("0.0.0.0:8080")
}
