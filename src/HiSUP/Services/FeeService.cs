using HiSUP.Data;
using Microsoft.Data.SqlClient;

namespace HiSUP.Services
{
    public class FeeService
    {
        private readonly HiSUPContext _context;
        private readonly IConfiguration _config;

        public FeeService(HiSUPContext context, IConfiguration config)
        {
            _context = context;
            _config  = config;
        }

        // ── Process fee payment via stored procedure ──────────
        public async Task<int> ProcessPaymentAsync(
            int studentId, int feeStructureId,
            decimal amount, string referenceNo,
            string? bankAccount = null)
        {
            int retries = 0;
            while (retries < 3)
            {
                try
                {
                    var connStr = _config.GetConnectionString("HiSUP_DB");
                    await using var conn = new SqlConnection(connStr);
                    await conn.OpenAsync();

                    await using var cmd = new SqlCommand("ProcessFeePayment", conn)
                    {
                        CommandType = System.Data.CommandType.StoredProcedure
                    };

                    cmd.Parameters.AddWithValue("@StudentID",        studentId);
                    cmd.Parameters.AddWithValue("@FeeStructureID",   feeStructureId);
                    cmd.Parameters.AddWithValue("@AmountPaid",       amount);
                    cmd.Parameters.AddWithValue("@ReferenceNo",      referenceNo);
                    cmd.Parameters.AddWithValue("@BankAccountPlain", (object?)bankAccount ?? DBNull.Value);

                    var outParam = new SqlParameter("@PaymentID", System.Data.SqlDbType.Int)
                    {
                        Direction = System.Data.ParameterDirection.Output
                    };
                    cmd.Parameters.Add(outParam);

                    await cmd.ExecuteNonQueryAsync();
                    return (int)outParam.Value;
                }
                catch (SqlException ex) when (ex.Number == 1205) // Deadlock victim
                {
                    retries++;
                    if (retries >= 3) throw;
                    await Task.Delay(200 * retries); // Back off before retry
                }
            }
            throw new Exception("Payment failed after 3 retries.");
        }
    }
}
