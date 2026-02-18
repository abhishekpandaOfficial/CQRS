FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

COPY ["CqrsCatalog.slnx", "."]
COPY ["src/Catalog.Write.Api/Catalog.Write.Api.csproj", "src/Catalog.Write.Api/"]
COPY ["src/Catalog.Write.Application/Catalog.Write.Application.csproj", "src/Catalog.Write.Application/"]
COPY ["src/Catalog.Write.Domain/Catalog.Write.Domain.csproj", "src/Catalog.Write.Domain/"]
COPY ["src/Catalog.Write.Infrastructure/Catalog.Write.Infrastructure.csproj", "src/Catalog.Write.Infrastructure/"]
COPY ["src/Catalog.Shared/Catalog.Shared.csproj", "src/Catalog.Shared/"]

RUN dotnet restore "src/Catalog.Write.Api/Catalog.Write.Api.csproj"

COPY . .
RUN dotnet publish "src/Catalog.Write.Api/Catalog.Write.Api.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS final
WORKDIR /app
COPY --from=build /app/publish .

EXPOSE 8080
ENV ASPNETCORE_URLS=http://+:8080

ENTRYPOINT ["dotnet", "Catalog.Write.Api.dll"]
