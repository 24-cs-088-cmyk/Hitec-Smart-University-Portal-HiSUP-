using HiSUP.Data;
using HiSUP.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace HiSUP.Controllers
{
    [Authorize]
    public class LibraryController : Controller
    {
        private readonly HiSUPContext  _context;
        private readonly LibraryService _libraryService;

        public LibraryController(HiSUPContext context, LibraryService libraryService)
        {
            _context        = context;
            _libraryService = libraryService;
        }

        public async Task<IActionResult> Index(string? search)
        {
            if (!string.IsNullOrEmpty(search))
            {
                var results = await _libraryService.SearchAsync(search);
                ViewBag.Search = search;
                return View(results);
            }

            var items = await _context.LibraryItems.ToListAsync();
            return View(items);
        }
    }
}
