class AppSubjectList {
  static List<String> primarySubjects = [
    "Primary School Subjects",
    "Bangla",
    "English",
    "Mathematics",
    "Bangladesh & Global Studies",
    "Science",
    "Religion & Moral Education",
    "ICT",
    "Physical Education & Health",
    "Arts & Crafts",
  ];
  static List<String> highSchoolSubjects = [
    "high School Subjects",
    "Bangla 1st Paper",
    "Bangla 2nd Paper",
    "English 1st Paper",
    "English 2nd Paper",
    "Mathematics",
    "Science",
    "Bangladesh & Global Studies",
    "ICT",
    "Religion & Moral Education",
    "Higher Math",
    "Agriculture Studies",
    "Home Science",
    "Arts & Crafts",
    "Music",
  ];
  static List<String> sscScience = [
    "Ssc Science",
    "Bangla",
    "English",
    "Mathematics",
    "Religion",
    "ICT",
    "Bangladesh & Global Studies",
    "Physics",
    "Chemistry",
    "Biology",
    "Higher Math",
  ];
  static List<String> sscCommerce = [
    "SSC Commerce"
    "Bangla",
    "English",
    "Mathematics",
    "ICT",
    "Religion",
    "Bangladesh & Global Studies",
    "Accounting",
    "Finance & Banking",
    "Business Entrepreneurship",
  ];
  static List<String> sscArts = [
    "SSC ARTS"
    "Bangla",
    "English",
    "ICT",
    "Religion",
    "Bangladesh & Global Studies",
    "General Science",
    "Geography & Environment",
    "History of Bangladesh & World Civilization",
    "Civics & Citizenship",
    "Economics",
    "Home Economics",
  ];
  static List<String> hscScience = [
    "HSC SCIENCE",
    "Physics",
    "Chemistry",
    "Biology",
    "Higher Math",
    "ICT",
    "Bangla",
    "English",
    "Statistics",
  ];
  static List<String> hscCommerce = [
    "HSC Commerce"
    "Accounting",
    "Business Organization & Management",
    "Finance & Banking",
    "Production Management & Marketing",
    "ICT",
    "Bangla",
    "English",
    "Statistics",
  ];
  static List<String> hscArts = [
    "Hsc Arts"
    "Civics & Good Governance",
    "Social Work",
    "Geography",
    "Economics",
    "Logic",
    "History",
    "Islamic Studies",
    "Psychology",
    "Arts & Crafts",
    "Bangla",
    "English",
    "ICT",
  ];
  static List<String> get allSubjects {
    return [
      ...primarySubjects,
      ...highSchoolSubjects,
      ...sscScience,
      ...sscCommerce,
      ...sscArts,
      ...hscScience,
      ...hscCommerce,
      ...hscArts,
    ];
  }
}


