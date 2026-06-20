package main

import (
	"context"
	"go/constant"
	"log"

	"github.com/jackc/pgx/v5/pgxpool"
)

func main(){

	ctx := context.Background()
	dbURL  := "postgres://postgres:password@localhost:5432/harvest_shop?sslmode=disable"
	dbPool, err := pgxpool.New(ctx, dbURL)
	if err != nil {
		log.Fatal("Cannot connect to db pool")
	}

	defer dbPool.Close()

	
}

