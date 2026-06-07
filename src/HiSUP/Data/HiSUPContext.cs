using HiSUP.Models;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;

namespace HiSUP.Data
{
    public class HiSUPContext : IdentityDbContext<ApplicationUser>
    {
        public HiSUPContext(DbContextOptions<HiSUPContext> options) : base(options) { }

        // ── DbSets ───────────────────────────────────────────
        public DbSet<Department>        Departments        { get; set; }
        public DbSet<UniversityProgram> Programs           { get; set; }
        public DbSet<Student>           Students           { get; set; }
        public DbSet<Faculty>           Faculty            { get; set; }
        public DbSet<Course>            Courses            { get; set; }
        public DbSet<Section>           Sections           { get; set; }
        public DbSet<Enrollment>        Enrollments        { get; set; }
        public DbSet<Grade>             Grades             { get; set; }
        public DbSet<AttendanceRecord>  AttendanceRecords  { get; set; }
        public DbSet<FeeStructure>      FeeStructures      { get; set; }
        public DbSet<FeePayment>        FeePayments        { get; set; }
        public DbSet<LibraryItem>       LibraryItems       { get; set; }
        public DbSet<LibraryIssue>      LibraryIssues      { get; set; }
        public DbSet<AuditLog>          AuditLogs          { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // ── Unique constraints ────────────────────────────
            modelBuilder.Entity<Student>()
                .HasIndex(s => s.Email).IsUnique();

            modelBuilder.Entity<Faculty>()
                .HasIndex(f => f.Email).IsUnique();

            modelBuilder.Entity<Enrollment>()
                .HasIndex(e => new { e.StudentID, e.SectionID }).IsUnique();

            // ── Self-referencing Course prerequisite ─────────
            modelBuilder.Entity<Course>()
                .HasOne(c => c.Prerequisite)
                .WithMany()
                .HasForeignKey(c => c.PrerequisiteCourseID)
                .OnDelete(DeleteBehavior.NoAction);

            // ── Enrollment → Section: no cascade ─────────────
            modelBuilder.Entity<Enrollment>()
                .HasOne(e => e.Section)
                .WithMany(s => s.Enrollments)
                .HasForeignKey(e => e.SectionID)
                .OnDelete(DeleteBehavior.NoAction);

            // ── AttendanceRecord → Section: no cascade ────────
            modelBuilder.Entity<AttendanceRecord>()
                .HasOne(a => a.Section)
                .WithMany(s => s.AttendanceRecords)
                .HasForeignKey(a => a.SectionID)
                .OnDelete(DeleteBehavior.NoAction);

            // ── FeePayment → FeeStructure: no cascade ─────────
            modelBuilder.Entity<FeePayment>()
                .HasOne(fp => fp.FeeStructure)
                .WithMany()
                .HasForeignKey(fp => fp.FeeStructureID)
                .OnDelete(DeleteBehavior.NoAction);

            // ── Decimal precision ─────────────────────────────
            modelBuilder.Entity<Student>()
                .Property(s => s.CGPA).HasPrecision(3, 2);

            modelBuilder.Entity<Grade>()
                .Property(g => g.MarksObtained).HasPrecision(5, 2);

            modelBuilder.Entity<Grade>()
                .Property(g => g.GradePoints).HasPrecision(3, 2);

            modelBuilder.Entity<FeePayment>()
                .Property(f => f.AmountPaid).HasPrecision(10, 2);

            modelBuilder.Entity<FeeStructure>()
                .Property(f => f.Amount).HasPrecision(10, 2);

            modelBuilder.Entity<LibraryIssue>()
                .Property(l => l.Fine).HasPrecision(8, 2);
        }
    }
}
