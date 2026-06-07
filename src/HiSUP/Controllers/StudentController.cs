using HiSUP.Data;
using HiSUP.Models;
using HiSUP.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace HiSUP.Controllers
{
    [Authorize(Roles = "Student,Admin")]
    public class StudentController : Controller
    {
        private readonly HiSUPContext                 _context;
        private readonly UserManager<ApplicationUser> _userManager;
        private readonly StudentService               _studentService;

        public StudentController(
            HiSUPContext context,
            UserManager<ApplicationUser> userManager,
            StudentService studentService)
        {
            _context        = context;
            _userManager    = userManager;
            _studentService = studentService;
        }

        // ── Dashboard ─────────────────────────────────────────
        public async Task<IActionResult> Index()
        {
            var user = await _userManager.GetUserAsync(User);

            // Try to find linked student record
            var student = await _context.Students
                .Include(s => s.Department)
                .Include(s => s.Program)
                .FirstOrDefaultAsync(s => s.UserAccountID == user!.Id);

            // If no student record linked yet, show first student as demo
            if (student == null)
            {
                student = await _context.Students
                    .Include(s => s.Department)
                    .Include(s => s.Program)
                    .FirstOrDefaultAsync();
            }

            if (student == null)
            {
                ViewBag.Student     = null;
                ViewBag.Enrollments = new List<Enrollment>();
                return View();
            }

            var enrollments = await _context.Enrollments
                .Include(e => e.Section)
                    .ThenInclude(sec => sec!.Course)
                .Include(e => e.Section)
                    .ThenInclude(sec => sec!.Faculty)
                .Include(e => e.Grade)
                .Where(e => e.StudentID == student.StudentID && e.Status == "Active")
                .ToListAsync();

            ViewBag.Student     = student;
            ViewBag.Enrollments = enrollments;
            return View();
        }

        // ── Course Registration ───────────────────────────────
        public async Task<IActionResult> Courses()
        {
            var sections = await _context.Sections
                .Include(s => s.Course)
                    .ThenInclude(c => c!.Department)
                .Include(s => s.Faculty)
                .Where(s => s.SeatsAvailable > 0)
                .ToListAsync();
            return View(sections);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Enroll(int sectionId)
        {
            try
            {
                var user    = await _userManager.GetUserAsync(User);
                var student = await _context.Students
                    .FirstOrDefaultAsync(s => s.UserAccountID == user!.Id)
                    ?? await _context.Students.FirstOrDefaultAsync();

                if (student == null)
                    return Json(new { success = false, message = "No student record found." });

                var enrollmentId = await _studentService.EnrollInCourseAsync(
                    student.StudentID, sectionId);

                return Json(new { success = true, enrollmentId });
            }
            catch (Exception ex)
            {
                return Json(new { success = false, message = ex.Message });
            }
        }

        // ── Fee History ───────────────────────────────────────
        public async Task<IActionResult> Fees()
        {
            var user    = await _userManager.GetUserAsync(User);
            var student = await _context.Students
                .FirstOrDefaultAsync(s => s.UserAccountID == user!.Id)
                ?? await _context.Students.FirstOrDefaultAsync();

            if (student == null)
            {
                ViewBag.Student  = null;
                ViewBag.Payments = new List<FeePayment>();
                return View();
            }

            var payments = await _context.FeePayments
                .Include(f => f.FeeStructure)
                .Where(f => f.StudentID == student.StudentID)
                .OrderByDescending(f => f.PaymentDate)
                .ToListAsync();

            ViewBag.Student  = student;
            ViewBag.Payments = payments;
            return View();
        }

        // ── Transcript ────────────────────────────────────────
        public async Task<IActionResult> Transcript()
        {
            var user    = await _userManager.GetUserAsync(User);
            var student = await _context.Students
                .Include(s => s.Department)
                .Include(s => s.Program)
                .FirstOrDefaultAsync(s => s.UserAccountID == user!.Id)
                ?? await _context.Students
                    .Include(s => s.Department)
                    .Include(s => s.Program)
                    .FirstOrDefaultAsync();

            if (student == null)
            {
                ViewBag.Student = null;
                ViewBag.Grades  = new List<Enrollment>();
                return View();
            }

            var grades = await _context.Enrollments
                .Include(e => e.Section)
                    .ThenInclude(s => s!.Course)
                .Include(e => e.Grade)
                .Where(e => e.StudentID == student.StudentID)
                .OrderBy(e => e.Section!.SemesterLabel)
                .ToListAsync();

            ViewBag.Student = student;
            ViewBag.Grades  = grades;
            return View();
        }
    }
}
