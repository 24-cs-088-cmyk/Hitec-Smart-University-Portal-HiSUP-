using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace HiSUP.Models
{
    public class Student
    {
        [Key] public int StudentID { get; set; }
        [Required] public int DepartmentID { get; set; }
        [Required] public int ProgramID { get; set; }
        public string? UserAccountID { get; set; }
        [Required, MaxLength(50)] public string FirstName { get; set; } = string.Empty;
        [Required, MaxLength(50)] public string LastName  { get; set; } = string.Empty;
        [Required, EmailAddress, MaxLength(100)] public string Email { get; set; } = string.Empty;
        public byte[]? CNIC { get; set; }
        public DateTime EnrollmentDate { get; set; } = DateTime.Now;
        [Range(1, 8)] public int CurrentSemester { get; set; } = 1;
        [Range(0, 4)] public decimal CGPA { get; set; } = 0;
        public bool IsActive { get; set; } = true;
        [ForeignKey("DepartmentID")] public Department? Department { get; set; }
        [ForeignKey("ProgramID")] public UniversityProgram? Program { get; set; }
        public ICollection<Enrollment>  Enrollments  { get; set; } = new List<Enrollment>();
        public ICollection<FeePayment>  FeePayments  { get; set; } = new List<FeePayment>();
        public ICollection<LibraryIssue> LibraryIssues { get; set; } = new List<LibraryIssue>();
        [NotMapped] public string FullName => $"{FirstName} {LastName}";
    }
}
