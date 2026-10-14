.PHONY: watch build clean analyze test get

## Code Generation
watch:
	dart run build_runner watch --delete-conflicting-outputs

build:
	dart run build_runner build --delete-conflicting-outputs

clean:
	dart run build_runner clean
	flutter clean

## Analysis & Testing
analyze:
	flutter analyze

test:
	flutter test

## Dependencies
get:
	flutter pub get

## Mock Server
server:
	cd tools/mock_server && dart run bin/server.dart

server-get:
	cd tools/mock_server && dart pub get

