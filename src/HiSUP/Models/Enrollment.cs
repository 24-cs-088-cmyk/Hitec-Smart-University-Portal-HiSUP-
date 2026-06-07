using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace HiSUP.Models
{
    public class Enrollment
    {
        [Key] public int EnrollmentID { get; set; }
        [Required] public int StudentID { get; set; }
        [Required] public int SectionID { get; set; }
        public DateTime EnrollmentDate { get; set; } = DateTime.Now;
        [MaxLength(20)] public string Status { get; set; } = "Active";
        [ForeignKey("StudentID")] public Student? Student { get; set; }
        [ForeignKey("SectionID")] public Section? Section { get; set; }
        public Grade? Grade { get; set; }
    }
}
