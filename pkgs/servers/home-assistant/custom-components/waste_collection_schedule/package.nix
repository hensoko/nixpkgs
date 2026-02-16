{
  lib,
  buildHomeAssistantComponent,
  fetchpatch,
  fetchFromGitHub,
  beautifulsoup4,
  cloudscraper,
  icalendar,
  icalevents,
  lxml,
  pycryptodome,
  pypdf,
  pymupdf,
}:

let
  fixEncodingPatch = fetchpatch {
    url = "https://github.com/mampfes/hacs_waste_collection_schedule/commit/f5eb6f44ab40a1a14280ceb903f68195afb367d4.patch";
    hash = "sha256-PmUb5MJpz6TttgUKeMZUmsD6ZQMO8+MVNI5pjQQYOQI=";
  };
in
buildHomeAssistantComponent rec {
  owner = "mampfes";
  domain = "waste_collection_schedule";
  version = "2.11.0";

  src = fetchFromGitHub {
    inherit owner;
    repo = "hacs_waste_collection_schedule";
    tag = version;
    hash = "sha256-+yt6kjUV+fqbOa7jj603XdGX7XtI8mXnCnmUjYFNA7c=";
  };

  patches = [ fixEncodingPatch ];

  dependencies = [
    beautifulsoup4
    cloudscraper
    icalendar
    icalevents
    lxml
    pycryptodome
    pypdf
    pymupdf
  ];

  meta = {
    changelog = "https://github.com/mampfes/hacs_waste_collection_schedule/releases/tag/${version}";
    description = "Home Assistant integration framework for (garbage collection) schedules";
    homepage = "https://github.com/mampfes/hacs_waste_collection_schedule";
    maintainers = with lib.maintainers; [ jamiemagee ];
    license = lib.licenses.mit;
  };
}
