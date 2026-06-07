using HiSUP.Data;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;

namespace HiSUP.Services
{
    public class StudentService
    {
        private readonly HiSUPContext _context;
        private readonly IConfiguration _config;

        public StudentService(HiSUPContext context, IConfiguration config)
        {
            _context = context;
            _config  = config;
        }

        // ── Call RegisterStudent stored procedure via ADO.NET ─
        public async Task<int> RegisterStudentAsync(
            string firstName, string lastName,
            string email, int deptId, int programId,
            string? userId = null)
        {
            var connStr = _config.GetConnectionString("HiSUP_DB");
            await using var conn = new SqlConnection(connStr);
            await conn.OpenAsync();

            await using var cmd = new SqlCommand("RegisterStudent", conn)
            {
                CommandType = System.Data.CommandType.StoredProcedure
            };

            cmd.Parameters.AddWithValue("@FirstName",     firstName);
            cmd.Parameters.AddWithValue("@LastName",      lastName);
            cmd.Parameters.AddWithValue("@Email",         email);
            cmd.Parameters.AddWithValue("@DepartmentID",  deptId);
            cmd.Parameters.AddWithValue("@ProgramID",     programId);
            cmd.Parameters.AddWithValue("@UserAccountID", (object?)userId ?? DBNull.Value);

            var outParam = new SqlParameter("@NewStudentID", System.Data.SqlDbType.Int)
            {
                Direction = System.Data.ParameterDirection.Output
            };
            cmd.Parameters.Add(outParam);

            await cmd.ExecuteNonQueryAsync();
            return (int)outParam.Value;
        }

        // ── Enroll student via stored procedure ───────────────
        public async Task<int> EnrollInCourseAsync(int studentId, int sectionId)
        {
            var connStr = _config.GetConnectionString("HiSUP_DB");
            await using var conn = new SqlConnection(connStr);
            await conn.OpenAsync();

            await using var cmd = new SqlCommand("EnrollInCourse", conn)
            {
                CommandType = System.Data.CommandType.StoredProcedure
            };

            cmd.Parameters.AddWithValue("@StudentID",  studentId);
            cmd.Parameters.AddWithValue("@SectionID",  sectionId);

            var outParam = new SqlParameter("@EnrollmentID", System.Data.SqlDbType.Int)
            {
                Direction = System.Data.ParameterDirection.Output
            };
            cmd.Parameters.Add(outParam);

            await cmd.ExecuteNonQueryAsync();
            return (int)outParam.Value;
        }

        // ── Get student dashboard via EF Core view ────────────
        public async Task<List<dynamic>> GetDashboardAsync(int studentId)
        {
            return await _context.Database
                .SqlQueryRaw<dynamic>(
                    "SELECT * FROM vw_StudentDashboard WHERE StudentID = {0}",
                    studentId)
                .ToListAsync();
        }
    }
}
