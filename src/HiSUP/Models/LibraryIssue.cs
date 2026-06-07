using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace HiSUP.Models
{
    [Table("LibraryIssues")]
    public class LibraryIssue
    {
        [Key] public int IssueID { get; set; }
        [Required] public int StudentID { get; set; }
        [Required] public int ItemID { get; set; }
        public DateTime IssueDate { get; set; } = DateTime.Now;
        public DateTime DueDate { get; set; }
        public DateTime? ReturnDate { get; set; }
        public decimal Fine { get; set; } = 0;
        [ForeignKey("StudentID")] public Student?     Student     { get; set; }
        [ForeignKey("ItemID")]    public LibraryItem? LibraryItem { get; set; }
    }
}
