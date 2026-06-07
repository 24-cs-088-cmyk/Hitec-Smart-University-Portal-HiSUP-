using Microsoft.AspNetCore.Mvc;

namespace HiSUP.Controllers
{
    public class HomeController : Controller
    {
        public IActionResult Index()
        {
            if (!User.Identity!.IsAuthenticated)
                return RedirectToAction("Login", "Account");

            if (User.IsInRole("Admin"))   return RedirectToAction("Index", "Admin");
            if (User.IsInRole("Faculty")) return RedirectToAction("Index", "Faculty");
            if (User.IsInRole("Finance")) return RedirectToAction("Index", "Finance");

            return RedirectToAction("Index", "Student");
        }

        public IActionResult Privacy() => View();
    }
}