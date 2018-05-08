var cryptoZombies;
var userAccount;

function startApp() {
	var cryptoZombiesAddress = "YOUR_CONTRACT_ADDRESS";
	cryptoZombies = new web3js.eth.Contract(cryptoZombiesABI, cryptoZombiesAddress);

	// looping to check if address changed
	var accountInterval = setInterval(function() {
      // Check if account has changed
      if (web3.eth.accounts[0] !== userAccount) {
        userAccount = web3.eth.accounts[0];
        // Call function to update the UI with the new account showing the zombies owned by selected account
        getZombiesByOwner(userAccount).then(displayZombies);
      }
    }, 100);

    // Subscribe events | Need to be sure the contract has been created
    // In order to filter events and only listen for changes related to the current user, our Solidity contract would have to use the indexed keyword, like we did in the Transfer event of our ERC721 implementation

    // Querying past events
    // We can even query past events using getPastEvents, and use the filters fromBlock and toBlock to give Solidity a time range for the event logs
    // Because you can use this method to query the event logs since the beginning of time, this presents an interesting use case: Using events as a cheaper form of storage.

    // For example, we could use this as a historical record of zombie battles
    // — we could create an event for every time one zombie attacks another and who won.
    // The smart contract doesn't need this data to calculate any future outcomes, but it's useful data for users to be able to browse from the app's front-end.

    cryptoZombies.events.Transfer({ filter: { _to: userAccount } })
		.on("data", function(event) {
		  let data = event.returnValues;
		  // $("#txStatus").text("Zombie" + data.name + "moved");
		  // The current user just received a zombie!
		  getZombiesByOwner(userAccount).then(displayZombies);
		}).on("error", console.error);

}

// Web3.js has two methods we will use to call functions on our contract: call and send.
// Call is used for view and pure functions. It won't create a transaction on the blockchain.
// Send will create a transaction and change data on the blockchain. You'll need to use send for any functions that aren't view or pure

function getZombieDetails(id) {
	// We had a `Zombie[] public zombies;`.
	// In Solidity, when you declare a variable public, it automatically creates a public "getter" function with the same name
	return cryptoZombies.methods.zombies(id).call()
}

function zombieToOwner(id) {
	return cryptoZombies.methods.zombieToOwner(id).call()
}

function getZombiesByOwner(owner) {
	return cryptoZombies.methods.getZombiesByOwner(owner).call()
}

function displayZombies(ids) {
	// clear the displayed army
	$("#zombies").empty();
	// for each zombie id ask the details and fill the div
	for (id of ids) {
	  getZombieDetails(id).then(function(zombie) {
		  // Using ES6's "template literals" to inject variables into the HTML.
		  // Append each one to our #zombies div
		  $("#zombies").append(
			  `<div class="zombie">
				<ul>
				  <li>Name: ${zombie.name}</li>
				  <li>DNA: ${zombie.dna}</li>
				  <li>Level: ${zombie.level}</li>
				  <li>Wins: ${zombie.winCount}</li>
				  <li>Losses: ${zombie.lossCount}</li>
				  <li>Ready Time: ${zombie.readyTime}</li>
				</ul>
			  </div>`
		  );
	  });
	}
}

function createRandomZombie(name) {
  // This is going to take a while, so update the UI to let the user know
  // the transaction has been sent
  $("#txStatus").text("Creating new zombie on the blockchain. This may take a while...");
  // Send the tx to our contract:
  // receipt will fire when the transaction is included into a block on Ethereum
  // error will fire if there's an issue the prevented the transaction from being included in a block, such as the user not sending enough gas
  return CryptoZombies.methods.createRandomZombie(name)
  .send({ from: userAccount })
  .on("receipt", function(receipt) {
    $("#txStatus").text("Successfully created " + name + "!");
    // Transaction was accepted into the blockchain, let's redraw the UI
    getZombiesByOwner(userAccount).then(displayZombies);
  })
  .on("error", function(error) {
    // Do something to alert the user their transaction has failed
    $("#txStatus").text(error);
  });
}

function feedOnKitty(zombieId, kittyId) {
  $("#txStatus").text("Eating a kitty. This may take a while...");
  return CryptoZombies.methods.feedOnKitty(zombieId, kittyId)
	  .send({ from: userAccount })
	  .on("receipt", function(receipt) {
		$("#txStatus").text("Ate a kitty and spawned a new Zombie!");
		getZombiesByOwner(userAccount).then(displayZombies);
	  })
	  .on("error", function(error) {
		$("#txStatus").text(error);
	  });
}

// Payable
function levelUp(zombieId) {
	$("#txStatus").text("Leveling up your zombie...");
	return CryptoZombies.methods.levelUp(zombieId)
	   .send({ from: userAccount, value: web3js.utils.toWei("0.001") })
	   .on("receipt", function(receipt) {
		   $("#txStatus").text("Power overwhelming! Zombie successfully leveled up");
	   })
	   .on("error", function(error) {
		   $("#txStatus").text(error);
	   });
}

window.addEventListener('load', function() {

	// Checking if Web3 has been injected by the browser (Mist/MetaMask)
	if (typeof web3 !== 'undefined') {
	// Use Mist/MetaMask's provider
	web3js = new Web3(web3.currentProvider);
	} else {
	// Handle the case where the user doesn't have web3. Probably
	// show them a message telling them to install Metamask in
	// order to use our app.
	}
	// Now you can start your app & access web3js freely:
	startApp()
})