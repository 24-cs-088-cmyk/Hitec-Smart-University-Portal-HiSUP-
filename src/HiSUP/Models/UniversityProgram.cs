using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace HiSUP.Models
{
    [Table("Programs")]
    public class UniversityProgram
    {
        [Key] public int ProgramID { get; set; }
        [Required] public int DepartmentID { get; set; }
        [Required, MaxLength(100)] public string ProgramName { get; set; } = string.Empty;
        [Required, MaxLength(20)]  public string Degree { get; set; } = string.Empty;
        public int DurationYears { get; set; } = 4;
        [ForeignKey("DepartmentID")] public Department? Department { get; set; }
    }
}
