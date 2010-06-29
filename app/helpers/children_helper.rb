module ChildrenHelper

  YOUNG_GENDERS = {
    "M" => "boy",
    "F" => "girl"
  }

  HE_SHE = {
    "M" => "he",
    "F" => "she"
  }

  def male_female?(gender)
    Child::GENDERS[gender]
  end

  def boy_girl?(gender)
    YOUNG_GENDERS[gender]
  end

  def he_she?(gender)
    HE_SHE[gender]
  end

end