using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace HiSUP.Models
{
    public class Grade
    {
        [Key] public int GradeID { get; set; }
        [Required] public int EnrollmentID { get; set; }
        [Range(0,100)] public decimal MarksObtained { get; set; }
        [MaxLength(2)] public string? LetterGrade { get; set; }
        [Range(0,4)]   public decimal? GradePoints { get; set; }
        public DateTime EnteredAt { get; set; } = DateTime.Now;
        [ForeignKey("EnrollmentID")] public Enrollment? Enrollment { get; set; }
    }
}
