using HiSUP.Data;
using HiSUP.Models;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;

namespace HiSUP.Services
{
    public class LibraryService
    {
        private readonly HiSUPContext _context;
        private readonly IConfiguration _config;

        public LibraryService(HiSUPContext context, IConfiguration config)
        {
            _context = context;
            _config  = config;
        }

        // ── Full-text search using CONTAINS ───────────────────
        public async Task<List<LibraryItem>> SearchAsync(string keyword)
        {
            return await _context.LibraryItems
                .FromSqlRaw(
                    "SELECT * FROM LibraryItems WHERE CONTAINS((Title, Author), {0})",
                    $"\"{keyword}\"")
                .ToListAsync();
        }

        // ── Issue book via stored procedure ───────────────────
        public async Task<int> IssueBookAsync(int studentId, int itemId, int dueDays = 14)
        {
            var connStr = _config.GetConnectionString("HiSUP_DB");
            await using var conn = new SqlConnection(connStr);
            await conn.OpenAsync();

            await using var cmd = new SqlCommand("IssueLibraryBook", conn)
            {
                CommandType = System.Data.CommandType.StoredProcedure
            };

            cmd.Parameters.AddWithValue("@StudentID", studentId);
            cmd.Parameters.AddWithValue("@ItemID",    itemId);
            cmd.Parameters.AddWithValue("@DueDays",   dueDays);

            var outParam = new SqlParameter("@IssueID", System.Data.SqlDbType.Int)
            {
                Direction = System.Data.ParameterDirection.Output
            };
            cmd.Parameters.Add(outParam);

            await cmd.ExecuteNonQueryAsync();
            return (int)outParam.Value;
        }

        // ── Return book via stored procedure ──────────────────
        public async Task<decimal> ReturnBookAsync(int issueId)
        {
            var connStr = _config.GetConnectionString("HiSUP_DB");
            await using var conn = new SqlConnection(connStr);
            await conn.OpenAsync();

            await using var cmd = new SqlCommand("ReturnLibraryBook", conn)
            {
                CommandType = System.Data.CommandType.StoredProcedure
            };

            cmd.Parameters.AddWithValue("@IssueID", issueId);

            var outParam = new SqlParameter("@Fine", System.Data.SqlDbType.Decimal)
            {
                Direction = System.Data.ParameterDirection.Output,
                Precision = 8, Scale = 2
            };
            cmd.Parameters.Add(outParam);

            await cmd.ExecuteNonQueryAsync();
            return (decimal)outParam.Value;
        }
    }
}
