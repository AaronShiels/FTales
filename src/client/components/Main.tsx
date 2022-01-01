import { FC, useState } from "react";

const Main: FC = () => {
	const [message, setMessage] = useState<string>();
	const handleClick = (): Promise<string> => new Promise((_) => setMessage("Hrrnghh"));

	return (
		<div>
			<h1>Hello world!</h1>
			<button onClick={handleClick}>Foo</button>
			{message}
		</div>
	);
};

export default Main;
