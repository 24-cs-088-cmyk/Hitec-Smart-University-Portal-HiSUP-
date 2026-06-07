using HiSUP.Data;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace HiSUP.Controllers
{
    [Authorize(Roles = "Faculty,Admin")]
    public class FacultyController : Controller
    {
        private readonly HiSUPContext _context;
        public FacultyController(HiSUPContext context) => _context = context;

        public async Task<IActionResult> Index()
        {
            var sections = await _context.Sections
                .Include(s => s.Course)
                .Include(s => s.Enrollments)
                .ToListAsync();
            ViewBag.Sections = sections;
            return View();
        }

        public async Task<IActionResult> Attendance()
        {
            var sections = await _context.Sections
                .Include(s => s.Course)
                .ToListAsync();
            return View(sections);
        }

        public async Task<IActionResult> Grades()
        {
            var enrollments = await _context.Enrollments
                .Include(e => e.Student)
                .Include(e => e.Section)
                    .ThenInclude(s => s!.Course)
                .Include(e => e.Grade)
                .ToListAsync();
            return View(enrollments);
        }
    }
}
