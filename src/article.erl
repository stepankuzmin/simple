-module(article).
-compile(export_all).

-record(article, {
	  date,
	  title,
    slug,
    tags,
    category,
    abstract,
	  content}).

get_date(Article) ->
    Article#article.date.

get_title(Article) ->
    Article#article.title.

get_abstract(Article) ->
    Article#article.abstract.

get_content(Article) ->
    Article#article.content.

set_attribute(Article, date, Date) -> Article#article{date = Date};
set_attribute(Article, title, Title) -> Article#article{title = Title}; 
set_attribute(Article, slug, Slug) -> Article#article{slug = Slug}; 
set_attribute(Article, tags, Tags) -> Article#article{tags = Tags}; 
set_attribute(Article, category, Category) -> Article#article{category = Category}; 
set_attribute(Article, abstract, Abstract) -> Article#article{abstract = Abstract}; 
set_attribute(Article, _, _) -> Article#article{}.

render_all() -> 
  "<ul>" ++ 
    lists:map(fun(Article) -> 
                "<li>" ++ article:render(Article) ++ "</li>" 
              end, 
              lists:map(fun(File) -> 
                          article:parse(File) 
                        end, 
                        filelib:wildcard("articles/*.md"))) ++ 
  "</ul>".

render(Article) ->
  ["<i>" ++ get_date(Article) ++ "</i>", 
    "<h2>" ++ get_title(Article) ++ "</h2>",
    "<p>" ++ get_abstract(Article) ++ "</p>"
  ].

parse(File) ->
  case file:read_file(File) of
    {ok, Data} -> 
      Lines = re:split(Data, "\n"),
      {Meta, Content} = lists:splitwith(fun(C) -> C =/= <<>> end, Lines),
      MetaArticle = prepare(split(Meta)),
      Article = MetaArticle#article{content = markdown:conv(string:join(lists:map(fun(String) -> binary:bin_to_list(String) end, Content), "\n"))},
      Article;
    {error, Reason} -> case Reason of
        enoent -> "The file \"" ++ File ++ "\" does not exist.";
        eacces -> "Missing permission for reading the file, or for searching one of the parent directories.";
        eisdir -> "The named file is a directory.";
        enotdir -> "A component of the file name is not a directory. On some platforms, enoent is returned instead.";
        enomem -> "There is not enough memory for the contents of the file.";
        _ -> "Unknown error."
      end
  end.

split(Data) ->
    split_acc(Data, []).

split_acc([], Acc) ->
    lists:reverse(Acc);

split_acc([H|T], Acc) ->
    {Key, Value} = lists:splitwith(fun(C) -> C =/= $: end, binary:bin_to_list(H)),
    split_acc(T, [{list_to_atom(Key), lists:dropwhile(fun(C) -> C =:= $: orelse C =:= $  end, Value)} | Acc]).
    
prepare(Meta) ->
    Article = #article{},
    prepare_acc(Meta, Article).

prepare_acc([], Article) ->
    Article;

prepare_acc([{Key, Value}|T], Article) ->
    NewArticle = set_attribute(Article, Key, Value),
    prepare_acc(T, NewArticle).
