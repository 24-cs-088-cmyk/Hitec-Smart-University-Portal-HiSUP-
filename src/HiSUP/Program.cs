using HiSUP.Data;
using HiSUP.Models;
using HiSUP.Services;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

// ── Database ──────────────────────────────────────────────────
builder.Services.AddDbContext<HiSUPContext>(options =>
    options.UseSqlServer(
        builder.Configuration.GetConnectionString("HiSUP_DB")));

// ── Identity ──────────────────────────────────────────────────
builder.Services.AddIdentity<ApplicationUser, IdentityRole>(options =>
{
    options.Password.RequireDigit           = true;
    options.Password.RequiredLength         = 8;
    options.Password.RequireNonAlphanumeric = false;
    options.Password.RequireUppercase       = false;
    options.SignIn.RequireConfirmedAccount  = false;
})
.AddEntityFrameworkStores<HiSUPContext>()
.AddDefaultTokenProviders();

// ── Cookie config ─────────────────────────────────────────────
builder.Services.ConfigureApplicationCookie(options =>
{
    options.LoginPath        = "/Account/Login";
    options.AccessDeniedPath = "/Account/AccessDenied";
});

// ── Services ──────────────────────────────────────────────────
builder.Services.AddScoped<StudentService>();
builder.Services.AddScoped<FeeService>();
builder.Services.AddScoped<LibraryService>();

// ── MVC ───────────────────────────────────────────────────────
builder.Services.AddControllersWithViews();

var app = builder.Build();

// ── Init DB and seed roles ────────────────────────────────────
using (var scope = app.Services.CreateScope())
{
    var db          = scope.ServiceProvider.GetRequiredService<HiSUPContext>();
    var roleManager = scope.ServiceProvider.GetRequiredService<RoleManager<IdentityRole>>();

    try
    {
        // Creates Identity tables if they don't exist
        // Does NOT touch your existing HiSUP_DB tables
        db.Database.EnsureCreated();

        // Seed roles
        string[] roles = { "Admin", "Student", "Faculty", "Finance" };
        foreach (var role in roles)
        {
            if (!await roleManager.RoleExistsAsync(role))
                await roleManager.CreateAsync(new IdentityRole(role));
        }
    }
    catch (Exception ex)
    {
        // Ignore DB startup errors on Somee so the website doesn't crash with 500.30
        Console.WriteLine("DB Init Error: " + ex.Message);
    }
}

if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Home/Error");
    app.UseHsts();
}

app.UseHttpsRedirection();
app.UseStaticFiles();
app.UseRouting();
app.UseAuthentication();
app.UseAuthorization();

app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Home}/{action=Index}/{id?}");

app.Run();
