package service

import (
	"context"
	"errors"
	"fmt"

	db "example.com/m/v2/db/sqlc"
	"example.com/m/v2/internal/repository"
	"example.com/m/v2/internal/utils"
)

type UserService interface {
	RegisterUser(ctx context.Context, arg db.CreateUserParams) (db.CreateUserRow, error)

	LoginUser(ctx context.Context, email string, password string) (db.GetUserByEmailRow, string, error)
	CompleteProfile(ctx context.Context, arg db.CreateOrUpdateProfileParams) (db.UserProfile, error)
	GetUserByEmail(ctx context.Context, arg string )(db.GetUserByEmailRow, error)
	GetUserList(ctx context.Context, arg db.ListCustomersParams)([]db.ListCustomersRow, error)
}

type userServiceStruct struct {
	repo repository.UserRepository
}

func NewUserService(repo repository.UserRepository) UserService {
	return &userServiceStruct{repo: repo}
}

// RegisterUser 
func (s *userServiceStruct) RegisterUser(ctx context.Context, arg db.CreateUserParams) (db.CreateUserRow, error) {
	existingUser, _ := s.repo.GetUserByEmail(ctx, arg.Email)
	if existingUser.Email == arg.Email {
		return db.CreateUserRow{}, errors.New("email already exists")
	}


	hashedPassword, err := utils.HashPassword(arg.PasswordHash) 
	if err != nil {
		return db.CreateUserRow{}, errors.New("failed to hash password")
	}
	arg.PasswordHash = hashedPassword

	return s.repo.CreateUser(ctx, arg)
}

// LoginUser 
func (s *userServiceStruct) LoginUser(ctx context.Context, email string, password string) (db.GetUserByEmailRow, string, error) {
	user, err := s.repo.GetUserByEmail(ctx, email)
	if err != nil {
		return db.GetUserByEmailRow{}, "", errors.New("user not found")
	}

	if !utils.CheckPasswordHash(password, user.PasswordHash) {
		return db.GetUserByEmailRow{}, "", errors.New("invalid password")
	}

    var userIDStr string
    src := user.ID.Bytes
    
    userIDStr = fmt.Sprintf("%x-%x-%x-%x-%x", src[0:4], src[4:6], src[6:8], src[8:10], src[10:16])
	token, err := utils.GenerateToken(userIDStr, user.Email , string(user.Role))
	if err != nil {
		return db.GetUserByEmailRow{}, "", errors.New("failed to generate token")
	}

	return user, token, nil
}

func (s *userServiceStruct) CompleteProfile(ctx context.Context, arg db.CreateOrUpdateProfileParams) (db.UserProfile, error) {
	return s.repo.CreateOrUpdateProfile(ctx, arg)
}

func (s *userServiceStruct) GetUserByEmail(ctx context.Context, arg string) (db.GetUserByEmailRow, error ){
	return  s.repo.GetUserByEmail(ctx, arg)
}

func (s *userServiceStruct) GetUserList (ctx context.Context, arg db.ListCustomersParams) ([]db.ListCustomersRow, error){
	return s.repo.ListCustomers(ctx, arg)
}