package service

import (
	"context"
	"errors"

	db "example.com/m/v2/db/sqlc"
	"example.com/m/v2/internal/repository"
)

// UserService interface 
type UserService interface {
	RegisterUser(ctx context.Context, arg db.CreateUserParams) (db.CreateUserRow, error)
	LoginUser(ctx context.Context, email string, password string) (db.GetUserByEmailRow, error)
	CompleteProfile(ctx context.Context, arg db.CreateOrUpdateProfileParams) (db.UserProfile, error)
}

// userServiceStruct 
type userServiceStruct struct {
	repo repository.UserRepository
}

// NewUserService 
func NewUserService(repo repository.UserRepository) UserService {
	return &userServiceStruct{
		repo: repo,
	}
}

// ==========================================
// ---- BUSINESS LOGIC IMPLEMENTATIONS ----
// ==========================================

// RegisterUser 
func (s *userServiceStruct) RegisterUser(ctx context.Context, arg db.CreateUserParams) (db.CreateUserRow, error) {
	existingUser, _ := s.repo.GetUserByEmail(ctx, arg.Email)
	if existingUser.Email == arg.Email {
		return db.CreateUserRow{}, errors.New("email already exists")
	}

	// arg.PasswordHash = hashPassword(arg.PasswordHash)
	return s.repo.CreateUser(ctx, arg)
}

func (s *userServiceStruct) LoginUser(ctx context.Context, email string, password string) (db.GetUserByEmailRow, error) {

	user, err := s.repo.GetUserByEmail(ctx, email)
	if err != nil {
		return db.GetUserByEmailRow{}, errors.New("user not found")
	}


	// if !checkPasswordHash(password, user.PasswordHash) {
	//     return db.GetUserByEmailRow{}, errors.New("invalid password")
	// }

	return user, nil
}


func (s *userServiceStruct) CompleteProfile(ctx context.Context, arg db.CreateOrUpdateProfileParams) (db.UserProfile, error) {

	return s.repo.CreateOrUpdateProfile(ctx, arg)
}