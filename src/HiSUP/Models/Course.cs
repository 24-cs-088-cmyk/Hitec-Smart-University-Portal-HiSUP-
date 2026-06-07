using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace HiSUP.Models
{
    public class Course
    {
        [Key] public int CourseID { get; set; }
        [Required] public int DepartmentID { get; set; }
        public int? PrerequisiteCourseID { get; set; }
        [Required, MaxLength(10)]  public string CourseCode { get; set; } = string.Empty;
        [Required, MaxLength(100)] public string CourseName { get; set; } = string.Empty;
        public int CreditHours { get; set; } = 3;
        public bool IsActive { get; set; } = true;
        [ForeignKey("DepartmentID")] public Department? Department { get; set; }
        [ForeignKey("PrerequisiteCourseID")] public Course? Prerequisite { get; set; }
        public ICollection<Section> Sections { get; set; } = new List<Section>();
    }
}
