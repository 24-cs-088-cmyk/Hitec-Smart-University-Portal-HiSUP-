using HiSUP.Data;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace HiSUP.Controllers
{
    [Authorize(Roles = "Finance,Admin")]
    public class FinanceController : Controller
    {
        private readonly HiSUPContext _context;
        public FinanceController(HiSUPContext context) => _context = context;

        public async Task<IActionResult> Index()
        {
            ViewBag.TotalCollected = await _context.FeePayments.SumAsync(f => f.AmountPaid);
            ViewBag.TotalPayments  = await _context.FeePayments.CountAsync();
            ViewBag.PendingCount   = await _context.FeePayments
                .CountAsync(f => f.Status == "Pending" || f.Status == "Partial");
            return View();
        }

        public async Task<IActionResult> Defaulters()
        {
            var payments = await _context.FeePayments
                .Include(f => f.Student)
                .Where(f => f.Status == "Pending" || f.Status == "Partial")
                .OrderByDescending(f => f.PaymentDate)
                .ToListAsync();
            return View(payments);
        }
    }
}
