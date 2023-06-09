function main()
	pkg load statistics

	X = dlmread("1.txt", ",");

	X = sort(X);

	% (a) минимальное и максимальное значение
	m_max = max(X);
	m_min = min(X);

    fprintf("(a) Максимальное значение выборки (M_max) = %f\n", m_max)
    fprintf("    Минимальное значение выборки  (M_min) = %f\n", m_min)
    fprintf("-------------------------------------------------\n")

	% (б) размах выборки
    r = m_max - m_min;
    fprintf("(б) Размах выборки (R) = %f\n", r)
    fprintf("------------------------------\n")

    % (в) вычисление оценок MX DX
    n = length(X);
    mu = sum(X) / n;
    s_2 = sum((X - mu).^2) / (n - 1);
    sigma = sqrt(s_2);

	fprintf("(в) Оценка математического ожидания (mu) = %f\n", mu)
    fprintf("    Оценка дисперсии (s_2) = %f\n", s_2)
    fprintf("----------------------------------------\n")

	% (г) группировка значений выборки в m = [log_2 n] + 2 интервала
	m = floor(log2(n)) + 2;

	bins = [];
	cur = m_min;

	for i = 1:(m + 1)
		bins(i) = cur;
		cur = cur + r / m;
	end

	eps = 1e-6;
	counts = [];
	j = 1;

	for i = 1:(m - 1)
		cur_count = 0;

		for j = 1:n

			if (bins(i) < X(j) || abs(bins(i) - X(j)) < eps) && X(j) < bins(i + 1)
				cur_count = cur_count + 1;
			endif

		endfor

		counts(i) = cur_count;
	endfor

	cur_count = 0;

	for j = 1:n

		if (bins(m) < X(j) || abs(bins(m) - X(j)) < eps) && (X(j) < bins(m + 1) || abs(bins(m + 1) - X(j)) < eps)
			cur_count = cur_count + 1;
		endif

    endfor

    counts(m) = cur_count;

    fprintf("(г) группировка значений выборки в m = [log_2 n] + 2 интервала:\n");

    for i = 1:(m - 1)
        fprintf("    [%f : %f) - %d вхожд.\n", bins(i), bins(i + 1), counts(i));
    end

    fprintf("    [%f : %f] - %d вхожд.\n", bins(m), bins(m + 1), counts(m));

    fprintf("----------------------------------------\n");

	% (д)  построение гистограммы и графика функции плотности

	fprintf("(д) построение гистограммы и графика функции плотности\n");
    fprintf("    распределения вероятностей нормальной случайной величины\n");

    figure;
    hold on;
    grid on;
	n = length(X);
	delta = r / m;
	middles = zeros(1, m);
	xx = zeros(1, m);

	for i = 1:m
		xx(i) = counts(i) / (n * delta);
	endfor

	for i = 1:m
		middles(i) = bins(i + 1) - (delta / 2);
	endfor

	fprintf("    высоты столбцов гистограммы:\n");

	for i = 1:m
		fprintf("    [%d] : %f\n", i, xx(i));
	endfor

	fprintf("[проверка] площадь гистограммы s = %f\n", sum(xx) * delta);

	set(gca, "xtick", bins);
	set(gca, "ytick", xx);
	set(gca, "xlim", [min(bins) - 1, max(bins) + 1]);
	bar(middles, xx, 1, "facecolor", "g", "edgecolor", "w");

	X_n = (m_min - 1):(sigma / 100):(m_max + 1);
	X_pdf = normpdf(X_n, mu, sigma);
	plot(X_n, X_pdf, "r");
    xlabel('X')
    ylabel('P')
    print -djpg hist.jpg
    hold off;

    fprintf("----------------------------------------\n");

	% (е) построение графика эмпирической функции распределения

    fprintf("(е) построение графика эмпирической функции распределения\n");
    fprintf("    и функции распределения нормальной случайной величины\n");

    figure;
    hold on;
    grid on;
	n = length(X);
	xx = zeros(1, m + 3);

	bins = [(min(bins) - 0.5) bins (max(bins) + 1)];
	counts = [0 counts 0];

	m = m + 2;

	acc = 0;

	for i = 2:m
		acc = acc + counts(i);
		xx(i) = acc / n;
	end

	xx(m + 1) = 1;

	X_n = (min(X) - 2):(sigma / 100):(max(X) + 2);
	X_cdf = normcdf(X_n, mu, sigma);
	plot(X_n, X_cdf, "r");


	for i = 2:m
		fprintf("x = %f : F(x) = %f\n", bins(i), xx(i));
	end


	set(gca, "xtick", bins);
	set(gca, "ylim", [0, 1.1]);
	set(gca, "ytick", xx);
	stairs(bins, xx);
    xlabel('X')
    ylabel('F')
    print -djpg cdf.jpg
    hold off;
end