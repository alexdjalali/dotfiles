# ~/.latexmkrc - Global latexmk configuration, and the one place latexmk flags
# live: VimTeX and texlab run plain `latexmk`.

# Use pdflatex by default
$pdf_mode = 1;
# The same flags for every engine (pdflatex, xelatex, lualatex, latex)
set_tex_cmds('-interaction=nonstopmode -synctex=1 -file-line-error %O %S');

# Shell escape (needed by minted and TikZ externalization) is off: it lets a
# document run commands. Opt in per project with a latexmkrc beside the .tex:
#   set_tex_cmds('-interaction=nonstopmode -synctex=1 -file-line-error -shell-escape %O %S');

# Preview with Skim on macOS
$pdf_previewer = 'open -a Skim';
$pdf_update_method = 4;  # run update command
$pdf_update_command = '/Applications/Skim.app/Contents/SharedSupport/displayline -g %R.pdf';

# Optimizations: reduce unnecessary passes
$bibtex_use = 1.5;                  # run bibtex/biber only when .bib changes
$recorder = 1;                      # use -recorder for dependency tracking

# Glossaries support (glossaries-extra)
add_cus_dep('glo', 'gls', 0, 'makeglossaries');
add_cus_dep('acn', 'acr', 0, 'makeglossaries');
sub makeglossaries {
  my ($base_name, $path) = fileparse( $_[0] );
  my @args = ( "-q", "-d", $path, $base_name );
  return system "makeglossaries", @args;
}
push @generated_exts, 'glo', 'gls', 'glg';
push @generated_exts, 'acn', 'acr', 'alg';

# Clean up extra generated files
$clean_ext = 'bbl nav out snm vrb fls fdb_latexmk synctex.gz run.xml bcf';

# TikZ externalization: look for externalized figures
push @generated_exts, 'dpth', 'md5', 'auxlock';
$hash_calc_ignore_pattern{'pdf'} = '^/(CreationDate|ModDate|ID)';
