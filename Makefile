
PROJECT_NAME := $(lastword $(MAKECMDGOALS))

.DEFAULT:
	@pwsh .\build.ps1 $(PROJECT_NAME)