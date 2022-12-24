#!/usr/bin/env perl

my $md = Markdown::Text::Converter->load();

$md->convert();

package Markdown::Text::Converter
{
	use Text::Markdown 'markdown';
	use feature qw|say|;
	
	sub load()
	{
		my $class = shift;
		my $files = [];
		
		# gather all local .md's
		while ($_ = glob(q|*.md|))
		{
			push  @{$files}, $_ if (-ef)
		}
		
		# needs to have .md's to proceed
		unless (@{$files} > 0)
		{
			say q|> no .md files detected so quitting!|;
			exit 69;
		}
		
		# goto menu shinanigans
		MENU:
		{
			say q|~|x25;
			say q|~ | . q|Markdown 2 HTML|;
			say q|~|x25;
			
			my $n = 0;
			print map { s`.*`$n++.q| - |.$&.qq|\n|`re } @{$files};
			
			say   q|~|x25;
			print q|> choose: |;
		}
		my $choice = <STDIN>;
		
		unless ($choice and $choice =~ m~^\d+$~ and $$files[$choice])
		{
			say q|> Incorrect Choice! Try again!|;
			# could have made this a sub but let's try goto instead :P
			goto MENU; 
		}

		return bless { file => $$files[$choice] }, $class;
	
	}
	
	sub convert()
	{
		my $self     = shift;
		
		# load .md file
		open my $md, q|<|, $$self{file} or die qq|> can't open $$self{file}\n|;
		my $html_converted = markdown(join q||, <$md>);
		close $md;
	
		# verify template
		my $template = q|template.html|;
		
		unless (-e $template)
		{
			say q|> Template file missing!|;
			exit 69;
		}
	
		# load html template
		open my $html, q|<|, $template or die qq|> can't open ${template}\n|;
		my $html_template = join q||, <$html>;
		close $html;
		
		# grab title
		my $title;
		$html_converted =~ s`(?x)
			(?<=<h1>)
			[[:alnum:][:punct:][:space:]]+
			(?=</h1>)
		`$title = $&`ier;

		# do conversions		
		$html_template =~ s`(?x)
			(INSERTTITLE)
			|
			INSERTBODY
		`  
			$1 ? $title : $html_converted; 
		`ge;
	
		# write output html
		my $output_file = $$self{file} =~ s~\.md$~q|-|.time().q|.html|~er;
		open my $out, q|>|, $output_file 
		or die qq|> can't write html output!\n|;

		say   $out $html_template;
		close $out;

		say qq|> written ${output_file}.. all done so quitting :)|;

	}
		
}

__END__









