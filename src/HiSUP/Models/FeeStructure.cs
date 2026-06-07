using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace HiSUP.Models
{
    public class FeeStructure
    {
        [Key] public int FeeStructureID { get; set; }
        [Required] public int ProgramID { get; set; }
        [Required, MaxLength(50)] public string FeeType { get; set; } = string.Empty;
        [Required] public decimal Amount { get; set; }
        public string? Semester { get; set; }
        [Required, MaxLength(10)] public string AcademicYear { get; set; } = string.Empty;
        [ForeignKey("ProgramID")] public UniversityProgram? Program { get; set; }
    }
}
