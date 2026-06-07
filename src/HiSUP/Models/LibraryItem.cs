using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace HiSUP.Models
{
    [Table("LibraryItems")]
    public class LibraryItem
    {
        [Key] public int ItemID { get; set; }
        [Required, MaxLength(200)] public string Title { get; set; } = string.Empty;
        [Required, MaxLength(100)] public string Author { get; set; } = string.Empty;
        [MaxLength(20)] public string? ISBN { get; set; }
        public string? Category { get; set; }
        public string? Publisher { get; set; }
        public int? PublishYear { get; set; }
        public int CopiesTotal { get; set; } = 1;
        public int CopiesAvailable { get; set; } = 1;
        public ICollection<LibraryIssue> LibraryIssues { get; set; } = new List<LibraryIssue>();
    }
}
