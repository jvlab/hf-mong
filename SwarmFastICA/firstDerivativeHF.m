%% First derivative of hermite function of order n
%% estimated recursively using hf(n) denoted by input hf

function dHdw = firstDerivativeHF(hf, n)
	% hf 2D if n>0, else 1D
	if n>0
		dHdw = sqrt(n/2) * hf(1, :) - sqrt((n+1)/2) * hf(2, :);
	else
		dHdw = -sqrt((n+1)/2) * hf;
	end
	clear hf n;
end