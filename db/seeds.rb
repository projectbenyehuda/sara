# This seed file should only be used in dev environment.
# Reset db state and adds there some metadata
ResponseItem.delete_all
Query.delete_all

q = Query.create(text: 'דוד פרישמן')

ResponseItem.create(
  query: q,
  source: :wikipedia,
  media_type: :text,
  title: 'Intro paragraph',
  text: <<~text
    וד פרישמן (31 בדצמבר 1859, זגייז', פולין – 4 באוגוסט 1922, ברלין) היה משורר, עורך, מבקר ספרות, מתרגם, 
     סופר, ופיליטוניסט עברי, מחלוצי הספרות העברית המודרנית. במשפטו הידוע: "מלאכת מחשבת - תחיית האומה" הביע את אמונתו
     בצורך בחיזוק האמנות והספרות בחיי העם היהודי. מבחינה פוליטית התנגד לתנועה הציונית ולא היה שותף לעמדותיה.
  text
)

ResponseItem.create(
  query: q,
  source: :national_library_of_israel,
  media_type: :text,
  title: 'book by F',
  url: 'https://www.nli.org.il/he/books/NNL_ALEPH002021836/NLI'
)

ResponseItem.create(
  query: q,
  source: :national_library_of_israel,
  media_type: :text,
  title: 'book by F',
  url: 'https://www.nli.org.il/he/books/NNL_ALEPH001179987/NLI'
)

ResponseItem.create(
  query: q,
  source: :national_library_of_israel,
  media_type: :audio,
  title: 'a text by Frischmann performed by Bertonov',
  url: 'https://www.nli.org.il/he/items/NNL_MUSIC_AL004392683/NLI'
)

ResponseItem.create(
  query: q,
  source: :national_library_of_israel,
  media_type: :image,
  title: 'portrait of F and Bialik',
  url: 'https://www.nli.org.il/he/archives/NNL_ARCHIVE_AL997009637569005171/NLI'
)

ResponseItem.create(
  query: q,
  source: :national_library_of_israel,
  media_type: :text,
  title: 'book by Herzl, translated by Frischmann',
  url: 'https://www.nli.org.il/he/books/NNL_ALEPH001893335/NLI'
)

ResponseItem.create(
  query: q,
  source: :national_library_of_israel,
  media_type: :text,
  title: 'book by F',
  url: 'https://www.nli.org.il/he/books/NNL_ALEPH002046649/NLI'
)

ResponseItem.create(
  query: q,
  source: :national_library_of_israel,
  media_type: :text,
  title: 'bilingual book by F (Hebrew-Hungarian)',
  url: 'https://www.nli.org.il/he/books/NNL_ALEPH002195359/NLI'
)

ResponseItem.create(
  query: q,
  source: :national_library_of_israel,
  media_type: :image,
  title: 'portrait of F',
  url: 'https://www.nli.org.il/he/archives/NNL_ARCHIVE_AL997009702799905171/NLI'
)

ResponseItem.create(
  query: q,
  source: :national_library_of_israel,
  media_type: :text,
  title: 'book by Borchardt, translated by Frischmann',
  url: 'https://www.nli.org.il/he/books/NNL_ALEPH001839264/NLI'
)

ResponseItem.create(
  query: q,
  source: :national_library_of_israel,
  media_type: :text,
  title: 'book by Grimm, translated by F',
  url: 'https://www.nli.org.il/he/books/NNL_ALEPH002510166/NLI'
)

ResponseItem.create(
  query: q,
  source: :national_library_of_israel,
  media_type: :text,
  title: 'book by F',
  url: 'https://www.nli.org.il/he/books/NNL_ALEPH002701033/NLI'
)

ResponseItem.create(
  query: q,
  source: :national_library_of_israel,
  media_type: :text,
  title: 'Bible text, with comments for children by F',
  url: 'https://www.nli.org.il/he/books/NNL_ALEPH002761068/NLI'
)

ResponseItem.create(
  query: q,
  source: :national_library_of_israel,
  media_type: :text,
  title: 'book by F',
  url: 'https://www.nli.org.il/he/books/NNL_ALEPH002046730/NLI'
)

ResponseItem.create(
  query: q,
  source: :national_library_of_israel,
  media_type: :text,
  title: 'book by Herzl, translated by Frischmann',
  url: 'https://www.nli.org.il/he/books/NNL_ALEPH001891192/NLI'
)

ResponseItem.create(
  query: q,
  source: :national_library_of_israel,
  media_type: :text,
  title: 'book by Herzl, translated by Frischmann',
  url: 'https://www.nli.org.il/he/books/NNL_ALEPH001893326/NLI'
)

ResponseItem.create(
  query: q,
  source: :national_library_of_israel,
  media_type: :text,
  title: 'book by Lord Byron, translated by F',
  url: 'https://www.nli.org.il/he/books/NNL_ALEPH001842235/NLI'
)

ResponseItem.create(
  query: q,
  source: :national_library_of_israel,
  media_type: :text,
  title: 'book by F',
  url: 'https://www.nli.org.il/he/books/NNL_ALEPH002046823/NLI'
)

ResponseItem.create(
  query: q,
  source: :national_library_of_israel,
  media_type: :text,
  title: 'letters from F to Volfovsky',
  url: 'https://www.nli.org.il/he/archives/NNL_ARCHIVE_AL997009756823105171/NLI'
)

ResponseItem.create(
  query: q,
  source: :national_library_of_israel,
  media_type: :audio,
  title: 'oratory by Paul Ben Haim to the text Book of Yoram by Borchardt translated by Frischmann',
  url: 'https://www.nli.org.il/he/items/NNL_MUSIC_AL000254497/NLI'
)

ResponseItem.create(
  query: q,
  source: :national_library_of_israel,
  media_type: :text,
  title: 'letters from Ravnitsky\'s archive. Some by or to F and others',
  url: 'https://www.nli.org.il/he/archives/NNL_ARCHIVE_AL003436586/NLI'
)

ResponseItem.create(
  query: q,
  source: :national_library_of_israel,
  media_type: :audio,
  title: 'recorded songs; the lyrics to one are by F',
  url: 'https://www.nli.org.il/he/items/NNL_MUSIC_AL000229686/NLI'
)

ResponseItem.create(
  query: q,
  source: :national_library_of_israel,
  media_type: :audio,
  title: 'recorded songs; the lyrics to one are by F',
  url: 'https://www.nli.org.il/he/items/NNL_MUSIC_AL000232275/NLI'
)

ResponseItem.create(
  query: q,
  source: :pby,
  media_type: :text,
  title: 'main page about Frischmann, linking to all his works in PBY, as well as (in sidebar), works *about* F',
  url: 'https://benyehuda.org/author/142'
)

ResponseItem.create(
  query: q,
  source: :pby,
  media_type: :text,
  title: 'first work in the page; all the rest of the works have similar URLs.  They are grouped by genre on the author page. Within each genre, some are grouped by book title',
  url: 'https://benyehuda.org/read/10874'
)

ResponseItem.create(
  query: q,
  source: :pby,
  media_type: :text,
  title: 'first work about F in F\'s page.',
  url: 'https://benyehuda.org/work/show/3350'
)

ResponseItem.create(
  query: q,
  source: :pby,
  media_type: :image,
  title: 'Profile illustation',
  url: 'https://s3.amazonaws.com/bybeprod/people/profile_images/000/000/142/thumb/Frishman_David_LR.jpg?1625869858'
)
