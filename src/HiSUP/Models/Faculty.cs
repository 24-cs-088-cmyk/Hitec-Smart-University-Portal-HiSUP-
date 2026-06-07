using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace HiSUP.Models
{
    public class Faculty
    {
        [Key] public int FacultyID { get; set; }
        [Required] public int DepartmentID { get; set; }
        public string? UserAccountID { get; set; }
        [Required, MaxLength(50)] public string FirstName { get; set; } = string.Empty;
        [Required, MaxLength(50)] public string LastName  { get; set; } = string.Empty;
        [Required, EmailAddress] public string Email { get; set; } = string.Empty;
        public string Designation { get; set; } = "Lecturer";
        public DateTime JoiningDate { get; set; } = DateTime.Now;
        [ForeignKey("DepartmentID")] public Department? Department { get; set; }
        public ICollection<Section> Sections { get; set; } = new List<Section>();
        [NotMapped] public string FullName => $"{FirstName} {LastName}";
    }
}
