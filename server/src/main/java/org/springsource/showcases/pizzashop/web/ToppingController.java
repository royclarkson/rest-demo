package org.springsource.showcases.pizzashop.web;

import java.util.List;

import javax.validation.Valid;

import org.springframework.http.HttpStatus;
import org.springframework.roo.addon.web.mvc.controller.scaffold.RooWebScaffold;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springsource.showcases.pizzashop.domain.Topping;


@RequestMapping("/toppings")
@Controller
@RooWebScaffold(path = "toppings", formBackingObject = Topping.class)
public class ToppingController {

	@ResponseStatus(HttpStatus.CREATED)
	@RequestMapping(method = RequestMethod.POST, consumes = "application/json", produces = "application/json")
	public @ResponseBody Topping createFromJson(@RequestBody Topping topping) {
		topping.persist();
		return Topping.findTopping(topping.getId());
	}

	@RequestMapping(value = "/{id}", produces = "application/json")
	public @ResponseBody Topping showJson(@PathVariable("id") Long id) {
		return Topping.findTopping(id);
	}

	@RequestMapping(method = RequestMethod.GET, produces = "application/json")
	public @ResponseBody List<Topping> listJson(@RequestParam(value = "page", required = false) Integer page, @RequestParam(value = "size", required = false) Integer size) {
		return getToppings(page, size);
	}

	@RequestMapping(method = RequestMethod.PUT, consumes = "application/json", produces = "application/json")
	public @ResponseBody Topping updateFromJson(@RequestBody Topping topping) {
		topping.merge();
		return Topping.findTopping(topping.getId());
	}

	@RequestMapping(value = "/{id}", method = RequestMethod.DELETE, produces = "application/json")
	public @ResponseBody List<Topping> deleteJson(@PathVariable("id") Long id, @RequestParam(value = "page", required = false) Integer page, @RequestParam(value = "size", required = false) Integer size) {
		Topping topping = Topping.findTopping(id);
		topping.remove();
		return getToppings(page, size);
	}

	// helpers

	private List<Topping> getToppings(Integer page, Integer size) {
		if (page != null || size != null) {
			int sizeNo = size == null ? 10 : size.intValue();
			final int firstResult = page == null ? 0 : (page.intValue() - 1) * sizeNo;
			return Topping.findToppingEntries(firstResult, sizeNo);
		} else {
			return Topping.findAllToppings();
		}
	}
}
