const getTale = async (): Promise<string> => {
	const response = await fetch(`${API_BASE_URL}/tales`);
	const content = await response.text();

	return content;
};

export { getTale };
