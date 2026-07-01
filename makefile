DB_URL=postgres://postgres@localhost:5432/my_test_db?sslmode=disable

# ==============================================================================
# 🧼 1. MIGRATION COMPILER (সুন্দর ব্লক কমেন্টসহ ফাইল জোড়া লাগানোর প্রো-স্ক্রিপ্ট)
# ==============================================================================
compile-migrations:
	@echo "🧼 Cleaning old compiled migrations..."
	@rm -f db/migrations/*_init.up.sql db/migrations/*_init.down.sql
	@mkdir -p db/migrations
	
	@echo "📦 Beautifully merging split files into 000001_init.up.sql..."
	@# একটি লুপ চালিয়ে প্রতিটা ফাইলের কোড নেওয়ার আগে ও পরে বর্ডার কমেন্ট অ্যাড করা হচ্ছে
	@for file in db/init_schema/*.sql; do \
		filename=$$(basename $$file); \
		echo "" >> db/migrations/000001_init.up.sql; \
		echo "-- ======================================================================" >> db/migrations/000001_init.up.sql; \
		echo "-- 📂 FROM FILE: $$filename" >> db/migrations/000001_init.up.sql; \
		echo "-- ======================================================================" >> db/migrations/000001_init.up.sql; \
		echo "" >> db/migrations/000001_init.up.sql; \
		cat $$file >> db/migrations/000001_init.up.sql; \
		echo "" >> db/migrations/000001_init.up.sql; \
	done
	
	@echo "📉 Creating 000001_init.down.sql for clean database resets..."
	@echo "DROP SCHEMA public CASCADE; CREATE SCHEMA public;" > db/migrations/000001_init.down.sql
	@echo "✅ Migration files are beautifully compiled and organized!"

# ==============================================================================
# 🚀 2. MIGRATION & SQLC COMMANDS
# ==============================================================================
migrate-up: compile-migrations
	@echo "🚀 Running golang-migrate up..."
	migrate -path db/migrations -database "$(DB_URL)" -verbose up

migrate-down: compile-migrations
	@echo "📉 Running golang-migrate down..."
	migrate -path db/migrations -database "$(DB_URL)" -verbose down 1

db-fresh: compile-migrations
	migrate -path db/migrations -database "$(DB_URL)" -verbose down 1
	migrate -path db/migrations -database "$(DB_URL)" -verbose up

generate:
	@echo "🔮 Generating SQLc Go code..."
	sqlc generate

# ==============================================================================
# 💻 3. DEVELOPMENT & PRODUCTION BUILD COMMANDS (নতুন যুক্ত হলো)
# ==============================================================================

# লোকাল সার্ভার নরমাল রান করার জন্য
run:
	@echo "🏃 Starting local server..."
	go run cmd/api/main.go

# 'air' দিয়ে হট-রিলোড বা লাইভ রিলোড রান করার জন্য (কোড চেঞ্জ করলে অটো রিস্টার্ট হবে)
dev: generate compile-migrations
	@echo "🔥 Starting Air live reloader..."
	air

# প্রোডাকশন লেভেলের জন্য ক্লিন বাইনারি বিল্ড করার কমান্ড
build: generate compile-migrations
	@echo "🏗️ Building production binary..."
	@mkdir -p bin
	CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags="-s -w" -o bin/api cmd/api/main.go
	@echo "🚀 Build successful! Binary saved in bin/api"

# বিল্ড করা পুরোনো ফাইল ডিলিট করে পরিষ্কার করার জন্য
clean:
	@echo "🧹 Cleaning built binaries..."
	@rm -rf bin
	@echo "✅ Workspace clean!"

.PHONY: compile-migrations migrate-up migrate-down db-fresh generate run dev build clean