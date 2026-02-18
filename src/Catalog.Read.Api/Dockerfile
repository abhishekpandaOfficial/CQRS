FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

COPY ["CqrsCatalog.slnx", "."]
COPY ["src/Catalog.Read.Api/Catalog.Read.Api.csproj", "src/Catalog.Read.Api/"]
COPY ["src/Catalog.Read.Infrastructure/Catalog.Read.Infrastructure.csproj", "src/Catalog.Read.Infrastructure/"]
COPY ["src/Catalog.Shared/Catalog.Shared.csproj", "src/Catalog.Shared/"]

RUN dotnet restore "src/Catalog.Read.Api/Catalog.Read.Api.csproj"

COPY . .
RUN dotnet publish "src/Catalog.Read.Api/Catalog.Read.Api.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS final
WORKDIR /app
COPY --from=build /app/publish .

EXPOSE 8080
ENV ASPNETCORE_URLS=http://+:8080

ENTRYPOINT ["dotnet", "Catalog.Read.Api.dll"]
