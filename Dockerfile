# Stage 1: Build the application using .NET SDK 8.0
FROM mcr.microsoft.com/dotnet/sdk:8.0-windowsservercore-ltsc2022 AS build-env
WORKDIR /app

# Copy the csproj and restore dependencies
COPY *.csproj ./
RUN dotnet restore

# Copy the remaining files and build the application
COPY . ./
RUN dotnet publish -c Release -o out

# Stage 2: Set up IIS and deploy the app
FROM mcr.microsoft.com/dotnet/aspnet:8.0-windowsservercore-ltsc2022
WORKDIR /inetpub/wwwroot

# Install IIS and ASP.NET
RUN powershell -NoProfile -Command \
    Install-WindowsFeature Web-Server; \
    Install-WindowsFeature Web-Asp-Net45; \
    Install-WindowsFeature Web-Net-Ext45; \
    Remove-Item -Recurse C:\inetpub\wwwroot\*

# Copy the app from the build container
COPY --from=build-env /app/out .

# Expose port 80 for IIS
EXPOSE 80

# Start IIS
ENTRYPOINT ["C:\\ServiceMonitor.exe", "w3svc"]