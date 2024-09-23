# Stage 1: Build the .NET application using SDK 8.0
FROM mcr.microsoft.com/dotnet/sdk:8.0-windowsservercore-ltsc2022 AS build-env
WORKDIR /app

# Copy the csproj and restore dependencies
COPY *.csproj ./
RUN dotnet restore

# Copy the rest of the files and build the application
COPY . ./
RUN dotnet publish -c Release -o out

# Stage 2: Use IIS on Windows Server Core for hosting
FROM mcr.microsoft.com/windows/servercore/iis:windowsservercore-ltsc2022
WORKDIR /inetpub/wwwroot

# Remove default IIS content
RUN powershell Remove-Item -Recurse C:\inetpub\wwwroot\*

# Copy the application from the build stage
COPY --from=build-env /app/out .

# Expose port 80 for HTTP traffic
EXPOSE 80

# Start IIS by default
ENTRYPOINT ["C:\\ServiceMonitor.exe", "w3svc"]