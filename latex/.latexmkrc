# ~/.latexmkrc - Global latexmk configuration
# Optimized for speed with VimTeX continuous compilation

# Use pdflatex by default
$pdf_mode = 1;
$pdflatex = 'pdflatex -interaction=nonstopmode -synctex=1 -shell-escape %O %S';

# Preview with Skim on macOS
$pdf_previewer = 'open -a Skim';
$pdf_update_method = 4;  # run update command
$pdf_update_command = '/Applications/Skim.app/Contents/SharedSupport/displayline -g %R.pdf';

# Optimizations: reduce unnecessary passes
$max_repeat = 5;                    # max compilation passes (default 5)
$bibtex_use = 1.5;                  # run bibtex/biber only when .bib changes
$recorder = 1;                      # use -recorder for dependency tracking

# Glossaries support (glossaries-extra)
add_cus_dep('glo', 'gls', 0, 'makeglossaries');
add_cus_dep('acn', 'acr', 0, 'makeglossaries');
sub makeglossaries {
  my ($base_name, $path) = fileparse( $_[0] );
  my @args = ( "-q", "-d", $path, $base_name );
  if ($silent) { unshift @args, "-q"; }
  return system "makeglossaries", @args;
}
push @generated_exts, 'glo', 'gls', 'glg';
push @generated_exts, 'acn', 'acr', 'alg';

# Clean up extra generated files
$clean_ext = 'bbl nav out snm vrb fls fdb_latexmk synctex.gz run.xml bcf';

# TikZ externalization: look for externalized figures
push @generated_exts, 'dpth', 'md5', 'auxlock';
$hash_calc_ignore_pattern{'pdf'} = '^/(CreationDate|ModDate|ID)';
