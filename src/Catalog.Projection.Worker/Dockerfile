FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

COPY ["CqrsCatalog.slnx", "."]
COPY ["src/Catalog.Projection.Worker/Catalog.Projection.Worker.csproj", "src/Catalog.Projection.Worker/"]
COPY ["src/Catalog.Read.Infrastructure/Catalog.Read.Infrastructure.csproj", "src/Catalog.Read.Infrastructure/"]
COPY ["src/Catalog.Shared/Catalog.Shared.csproj", "src/Catalog.Shared/"]

RUN dotnet restore "src/Catalog.Projection.Worker/Catalog.Projection.Worker.csproj"

COPY . .
RUN dotnet publish "src/Catalog.Projection.Worker/Catalog.Projection.Worker.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM mcr.microsoft.com/dotnet/runtime:10.0 AS final
WORKDIR /app
COPY --from=build /app/publish .

ENTRYPOINT ["dotnet", "Catalog.Projection.Worker.dll"]
