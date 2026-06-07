using HiSUP.Data;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;

namespace HiSUP.Data
{
    public class DesignTimeDbContextFactory : IDesignTimeDbContextFactory<HiSUPContext>
    {
        public HiSUPContext CreateDbContext(string[] args)
        {
            var optionsBuilder = new DbContextOptionsBuilder<HiSUPContext>();
            optionsBuilder.UseSqlServer(
                "Server=.;Database=HiSUP_DB;Trusted_Connection=True;TrustServerCertificate=True");
            return new HiSUPContext(optionsBuilder.Options);
        }
    }
}
