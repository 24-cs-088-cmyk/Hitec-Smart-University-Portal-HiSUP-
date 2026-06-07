using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace HiSUP.Models
{
    [Table("AttendanceRecords")]
    public class AttendanceRecord
    {
        [Key] public int AttendanceID { get; set; }
        [Required] public int StudentID { get; set; }
        [Required] public int SectionID { get; set; }
        public DateTime AttendanceDate { get; set; }
        [MaxLength(10)] public string Status { get; set; } = "Present";
        [ForeignKey("StudentID")] public Student? Student { get; set; }
        [ForeignKey("SectionID")] public Section? Section { get; set; }
    }
}
