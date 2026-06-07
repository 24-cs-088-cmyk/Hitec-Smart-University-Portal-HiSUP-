using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace HiSUP.Models
{
    public class Section
    {
        [Key] public int SectionID { get; set; }
        [Required] public int CourseID { get; set; }
        [Required] public int FacultyID { get; set; }
        [Required, MaxLength(20)] public string SemesterLabel { get; set; } = string.Empty;
        public int SeatsTotal { get; set; }
        public int SeatsAvailable { get; set; }
        public string? Room { get; set; }
        public string? Schedule { get; set; }
        [ForeignKey("CourseID")]  public Course?  Course  { get; set; }
        [ForeignKey("FacultyID")] public Faculty? Faculty { get; set; }
        public ICollection<Enrollment>       Enrollments       { get; set; } = new List<Enrollment>();
        public ICollection<AttendanceRecord> AttendanceRecords { get; set; } = new List<AttendanceRecord>();
    }
}
