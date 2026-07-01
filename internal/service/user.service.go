package service

import (
	"context"
	db "example.com/m/v2/db/sqlc"
	"example.com/m/v2/internal/repository"
)

type UserService interface {
	CreateUser(ctx context.Context, user db.CreateUserParams) (db.User, error)
}

type userService struct {
	userRepo repository.UserRepository
}

func NewUserService(userRepo repository.UserRepository) UserService {
	return &userService{userRepo: userRepo}
}

func (s *userService) CreateUser(ctx context.Context, user db.CreateUserParams) (db.User, error) {
	return s.userRepo.CreateUser(ctx, user)
}