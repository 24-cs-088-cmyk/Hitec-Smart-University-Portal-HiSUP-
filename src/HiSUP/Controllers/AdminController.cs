using HiSUP.Data;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace HiSUP.Controllers
{
    [Authorize(Roles = "Admin")]
    public class AdminController : Controller
    {
        private readonly HiSUPContext _context;
        public AdminController(HiSUPContext context) => _context = context;

        public async Task<IActionResult> Index()
        {
            ViewBag.TotalStudents  = await _context.Students.CountAsync();
            ViewBag.TotalFaculty   = await _context.Faculty.CountAsync();
            ViewBag.TotalCourses   = await _context.Courses.CountAsync();
            ViewBag.TotalPayments  = await _context.FeePayments.SumAsync(f => f.AmountPaid);
            return View();
        }

        public async Task<IActionResult> Students()
        {
            var students = await _context.Students
                .Include(s => s.Department)
                .Include(s => s.Program)
                .ToListAsync();
            return View(students);
        }

        public async Task<IActionResult> AuditLog()
        {
            var logs = await _context.AuditLogs
                .OrderByDescending(l => l.LoggedAt)
                .Take(100)
                .ToListAsync();
            return View(logs);
        }
    }
}
